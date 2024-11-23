import { build } from "esbuild";
import { glob } from "glob";

export const defaultNodeBundleOptions = {
    platform: "node",
    bundle: true,
    outdir: "./dist",
    outbase: ".",
};

export const defaultGlobOptions = {
    ignore: ["**/node_modules/", "**/*.test.ts"],
};

export async function bundleLambdaHandlers() {
    const opt = {
        platform: "node",
        bundle: true,
        outdir: "./dist",
        outbase: ".",
        entryPoints: await glob(
            "**/lambda-handlers/*.ts",
            {
                ignore: ["**/node_modules/", "**/*.test.ts"],
            }
        ),
    } 
    await build(opt);
}

