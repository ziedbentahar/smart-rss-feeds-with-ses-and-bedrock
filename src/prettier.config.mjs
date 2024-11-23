/** @type {import("prettier").Config} */
const config = {
    trailingComma: "es5",
    tabWidth: 4,
    singleQuote: false,
    endOfLine: "lf",
    printWidth: 120,
    overrides: [
      {
        files: ["*.json", "*.config.mjs", "*.config.ts", "*.yml"],
        options: {
          tabWidth: 2,
        },
      },
    ],
  };
  
  export default config;