local errorcode = {}

errorcode.SUCCESS = { errorcode = 0, msg = "success"}
errorcode.OFFLINE = { errorcode = 1, msg = "offline"}
errorcode.NOT_ENOUGH = { errorcode = 2, msg = "not enough"}

errorcode.PROP_UNSERVICEABLE = { errorcode = 4, msg = "prop don't user"}

return errorcode