// Compiled from sample-source/index.mason
//# sourceMappingURL=index.js.map
module.exports = function()
{
	var plus = require("./math").plus;
	var x = (3);
	var y = (4);
	console.log("x plus y is " + plus(x, y) + "");
	return {
		x: x,
		y: y
	}
}()
