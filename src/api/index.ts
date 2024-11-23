import { Hono } from "hono";
import { handle } from "hono/aws-lambda";
import { feeds } from "./routes/feeds";
import { newsletters } from "./routes/newsletters";
import { links } from "./routes/links";
import { home } from "./routes/home";

export const app = new Hono();

app.route("/", home);
app.route("/feeds", feeds);
app.route("/links", links);
app.route("/newsletters", newsletters);

export const handler = handle(app);
