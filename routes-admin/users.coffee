express = require("express")
router  = express.Router()

# WebAPI GET. 
router.post "/", (req, res) ->
  result =
    header:
      error: 
        code: 'Success'
        message: ''
    body: null

  res.json 200, result  
  return

# WebAPI GET. 
router.get "/", (req, res) ->
  result =
    header:
      error: 
        code: 'Success'
        message: ''
    body: null

  res.json 200, result  
  return

module.exports = router