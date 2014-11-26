express = require("express")
router  = express.Router()

# WebAPI POST. 
router.post "/access_token/", (req, res) ->
  result =
    header:
      error: 
        code: 'Success'
        message: ''
    body: null

  res.json 200, result  
  return

module.exports = router