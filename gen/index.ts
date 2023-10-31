import { SocketGenerator } from "./src/SocketGenerator";
import { TopGenerator } from "./src/TopGenerator";

const socketGen = new SocketGenerator();
socketGen.run();
Bun.write("../lib/socket.ex", socketGen.content);

const topGen = new TopGenerator();
topGen.run();
Bun.write("../lib/surrealix.ex", topGen.content);
