var express = require("express");

var router = express.Router();

router.get("/", (req, res) => {
  return res.send("it is get page from get Numbers");
});

router.post("/", (req, res) => {
  const { rawNumber } = req.body;
  const processedNumber = rawNumber ** 2;

  return res.json({
    rawNumber: `raw number taken from ASP CORE is ${rawNumber}`,
    processedNumber: `the square of number calculated in NODE FRAME work ${processedNumber}`,
  });
});

module.exports = router;
