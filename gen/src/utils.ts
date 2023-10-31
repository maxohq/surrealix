/**
 * Prepend each line for the string with some prefix
 * @param v
 * @param toPad
 * @returns
 */
export const lpad = (v: string, toPad: string) => {
  return v
    .split("\n")
    .map((line) => {
      return toPad + line;
    })
    .join("\n");
};

/**
 * Upcase first char in a string
 * @param v
 * @returns
 */
export const constantize = (v: string) => {
  let upper = v.substr(0, 1);
  return upper.toUpperCase() + v.slice(1, v.length);
};

export const escape = function (text: string) {
  return text.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&");
};

/**
 * Full console log output for serializable JS objects
 * @param a
 */
export const debug = (a: any) => {
  console.log(JSON.stringify(a, null, 4));
};
