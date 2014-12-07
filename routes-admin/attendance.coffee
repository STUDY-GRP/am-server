express = require("express")
router  = express.Router()

# WebAPI GET. 
router.get "/:id/:year/:month", (req, res) ->
  result =
    header:
      error: 
        code: 'Success'
        message: ''
    body: null

  res.json 200, result  
  return

module.exports = router