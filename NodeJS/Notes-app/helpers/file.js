const fs = require('fs');

const filepath = './db/data.json';


const write = (data) => fs.writeFileSync(filepath, JSON.stringify(data));

const read = () => {
    if (!fs.existsSync(filepath))
        return null;

    const info = fs.readFileSync(filepath, {encoding: 'utf-8'});

    if (info) return JSON.parse(info);
    else return {}
}

module.exports = { write, read }