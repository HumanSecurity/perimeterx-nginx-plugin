local px_common_utils = require('px.utils.pxcommonutils')
local px_constants = require('px.utils.pxconstants')
local hmac = require "resty.nettle.hmac"

local M = {}

function M.telemetry_check_header(px_config, px_client, px_headers, px_logger)
    local header_value = px_headers.get_header(px_constants.ENFORCER_TELEMETRY_HEADER)
    if not header_value then
        return
    end
    px_logger.debug('Received command to send enforcer telemetry')
    header_value = ngx.decode_base64(header_value)
    local split_header_value = string.split(header_value, ':')
    if #split_header_value ~= 2 then
        px_logger.debug('Malformed ' .. px_constants.ENFORCER_TELEMETRY_HEADER .. ' header: ' .. header_value)
        return
    end
    local timestamp = split_header_value[1]
    local given_hmac = string.upper(split_header_value[2])
    local hmac_raw = hmac('sha256', px_config.cookie_secret, timestamp)
    local generated_hmac = px_common_utils.to_hex(hmac_raw)
    if given_hmac == generated_hmac then
        local details = {}
		details.px_config = px_common_utils.filter_config(px_config);
		details.update_reason = 'command'
        px_client.send_enforcer_telmetry(details);
    else
        px_logger.debug(px_constants.ENFORCER_TELEMETRY_HEADER .. ' hmac validation failed. original: ' .. given_hmac .. '. generated hmac: ' .. generated_hmac)
    end
end

return M