const { read } = require("./helpers/file");
const { iMenu, addNote, delNote } = require("./helpers/inquirer");


const main = async() => {
    let cmd = '';

    // Reading the previous notes
    const notes = read();

    do {
        cmd = await iMenu();

        switch (cmd) {
            case 1:
                await addNote(notes);
                break;
            
            case 2:
                await delNote(notes);
                break
        
            default:
                break;
        }

    } while (cmd !== 3);
}

main();