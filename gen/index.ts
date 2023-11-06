import { SocketGenerator } from "./src/SocketGenerator";
import { TopGenerator } from "./src/TopGenerator";

const socketGen = new SocketGenerator();
socketGen.run();
await Bun.write(import.meta.dir + "/../lib/surrealix/socket.ex", socketGen.content);

const topGen = new TopGenerator();
topGen.run();
await Bun.write(import.meta.dir + "/../lib/surrealix.ex", topGen.content);
