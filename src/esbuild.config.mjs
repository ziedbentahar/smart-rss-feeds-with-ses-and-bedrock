import {
  cleanDistFolder,
  bundleLambdaHandlers,
} from "./bundle-tools.mjs";

await cleanDistFolder();

await bundleLambdaHandlers();


