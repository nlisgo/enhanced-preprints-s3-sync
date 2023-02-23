var fs = require('fs');

function fixXml(path) {
    // load the html file
    var fileContent = fs.readFileSync(path, 'utf8');

    // replace more complex patterns

    // <label>1</label><title> -> <title><label>1</label>
    fileContent = fileContent.replace(new RegExp('<label>(.*)</label>[\r\n]*<title>', 'mg'), '<title><label>$1</label> ');

    // <title>ALL CAPS INTRO</title> -> <title>All caps intro</title>
    fileContent = fileContent.replace(
      new RegExp('<title>([A-Z\\s]+)</title>', 'g'),
      (match, title) => {
        const exceptions = ['LTPA'];
        if (exceptions.includes(title)) {
          return match;
        }
        return `<title>${title.charAt(0).toUpperCase() + title.slice(1).toLowerCase()}</title>`;
      },
    );

    // fix citations
    // <ext-link ext-link-type="uri" xlink:href="https://doi.org/{doi}">https://doi.org/{doi}</ext-link> -> <pub-id pub-id-type="doi">{doi}</pub-id>
    fileContent = fileContent.replace(new RegExp('<ext-link ext-link-type="uri" xlink:href="https://doi.org/(.*?)">.*?</ext-link>', 'mg'), '<pub-id pub-id-type="doi">$1</pub-id>');


    fs.writeFileSync(path, fileContent);
}

try {
  fixXml(process.argv[2]);
} catch (error) {
  console.log(error);
  process.exit(1);
}
