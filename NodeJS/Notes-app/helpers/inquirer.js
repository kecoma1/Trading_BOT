const inquirer = require('inquirer');

const { read, write } = require('./file');

const options = [
    {
        type: 'list',
        name: 'option',
        message: 'What do you want to do?',
        choices: [
            {
                value: 1,
                name: 'Add a new note'
            }, {
                value: 2,
                name: 'Delete a note'
            }, {
                value: 3,
                name: 'Exit'
            }
        ]
    }
]


const iMenu = async() => {
    console.clear();
    
    const { option } = await inquirer.prompt(options);

    return option;
} 

const readInput = async(msg) => {
    const question = [
        {
            type: 'input',
            name: 'input',
            message: msg
        }
    ];

    const { input } = await inquirer.prompt(question);
    return input;
}

const addNote = async(notes) => {
    console.clear()

    const title = await readInput('Title: ');
    const text = await readInput('Text: ');

    notes[title] = text;

    write(notes);
}

const delNote = async(notes) => {
    console.clear()

    const title = await readInput('Title: ');

    if (notes[title]) {
        delete notes[title]
        write(notes);
    } else await readInput(`The note ${title} doesn't exist\nPRESS ENTER: `);
}


module.exports = { iMenu, addNote, delNote }