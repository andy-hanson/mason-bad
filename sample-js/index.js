// Compiled from sample-source/index.mason
//# sourceMappingURL=index.js.map
module.exports = function()
{
	var math = require("./math");
	var _43 = math["+"];
	var x = (3);
	var y = (4);
	console.log("x plus y is " + _43(x, y) + "");
	return {
		x: x,
		y: y
	}
}()
