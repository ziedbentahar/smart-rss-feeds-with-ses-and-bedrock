const prompt = `
Process the provided newsletter issue content in markdown format and generate a structured JSON output by performing the following tasks and adhering to the constraints:

<tasks> 
    * Summarize the most important topics in this newsletter. 
    * Identify and extract the list of content shared in the newsletter, including: 
        * Key topics, extracted as paragraphs. 
        * Articles 
        * Tutorials. 
        * Key events
    * For shared content, extract the most relevant link. For each link, generate a summary sentence related to it. Do not create a link if one is not provided in the newsletter. 
    * Exclude any irrelevant content, such as unsubscribe links, social media links, or advertisements. 
    * Do not invent topics or content that is not present in the newsletter. 
</tasks>

Here is the expected JSON schema for the output: 
<output-json-schema>
{{output_json_schema}}
</output-json-schema>

Here is the newsletter content: 
<newsletter-content>
{{newsletter_content}}
</newsletter-content>
`;

export const generatePromptForEmail = (newsletterContent: string, outputJsonSchema: string) => {
    return prompt
        .replace("{{newsletter_content}}", newsletterContent)
        .replace("{{output_json_schema}}", outputJsonSchema);
};
