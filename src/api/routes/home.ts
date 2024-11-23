import { Hono } from "hono";
import { html } from "hono/html";

export const home = new Hono().get("/", (c) => {
    return c.html(
        html`<!doctype html>
            <html>
                <head>
                    <style>
                        .center {
                            padding-top: 50vh;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                        }
                    </style>
                </head>
                <body>
                    <div class="center">✨🗞️</div>
                </body>
            </html>`.toString()
    );
});
