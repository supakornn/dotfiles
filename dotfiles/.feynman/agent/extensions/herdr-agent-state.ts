import { spawn } from "node:child_process";

const herdr = process.env.HERDR_BIN_PATH;
const pane = process.env.HERDR_PANE_ID;
let seq = Date.now();

function report(state: "idle" | "working" | "blocked", message?: string) {
	if (process.env.HERDR_ENV !== "1" || !herdr || !pane) return;
	spawn(
		herdr,
		[
			"pane", "report-agent", "--source", "feynman", "--agent", "feynman",
			"--state", state, "--seq", String(++seq),
			...(message ? ["--message", message] : []), pane,
		],
		{ detached: true, stdio: "ignore" },
	).unref();
}

export default function (pi: any) {
	let working = false;
	let blocked = 0;
	let message: string | undefined;
	const publish = () => report(blocked ? "blocked" : working ? "working" : "idle", message);

	pi.on("session_start", (_event: any, ctx: any) => {
		if (ctx?.mode === "tui") publish();
	});
	pi.on("agent_start", () => { working = true; publish(); });
	pi.on("agent_settled", () => { working = false; publish(); });
	pi.events.on("herdr:blocked", (event: any) => {
		if (event?.active) {
			blocked += 1;
			message = event.label;
		} else if (blocked > 0 && --blocked === 0) {
			message = undefined;
		}
		publish();
	});
}
