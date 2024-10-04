var express = require("express");
var path = require("path");
var cookieParser = require("cookie-parser");

var PORT = 3001;

var convertNumberRouter = require("./routes/convertnumber.js");

var app = express();

app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.json());

app.use("/", convertNumberRouter);

app.listen(PORT, () => {
  console.log(`get numbers server works at ${PORT}`);
});
