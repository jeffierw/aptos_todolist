require("dotenv").config();

const cli = require("@aptos-labs/ts-sdk/dist/common/cli/index.js");

async function test() {
  const move = new cli.Move();

  await move.test({
    packageDirectoryPath: "contract",
    namedAddresses: {
      todolist_addr: "0xc0a22c5608bf0f2ee21fc1732fe8ce0612182ce80bc525aea3e8d3d8548e8ace",
    },
  });
}
test();
