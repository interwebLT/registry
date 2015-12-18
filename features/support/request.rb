ADMIN_PREFIX  = 'admin '
ADMIN_MARKER  = 'for another partner'
UNDERSCORE  = '_'

DASH  = '-'
SPACE = ' '
BLANK = ''
DOUBLE_SPACE  = '  '

def build_request scenario:, resource:, action:
  request = "#{resource.to_s}/"

  if scenario.include? ADMIN_MARKER
    request << ADMIN_PREFIX
    scenario.sub! ADMIN_MARKER, BLANK
  end

  request << "#{action.to_s} #{scenario.downcase} request"

  request.gsub(DOUBLE_SPACE, UNDERSCORE).gsub(DASH, UNDERSCORE).gsub(SPACE, UNDERSCORE)
end

