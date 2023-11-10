import { ApiGenerator } from "./src/ApiGenerator";
import { MainGenerator } from "./src/MainGenerator";


const apiGen = new ApiGenerator();
apiGen.run();
await Bun.write(import.meta.dir + "/../lib/surrealix/api.ex", apiGen.content);

const mainGen = new MainGenerator();
mainGen.run();
await Bun.write(import.meta.dir + "/../lib/surrealix.ex", mainGen.content);
