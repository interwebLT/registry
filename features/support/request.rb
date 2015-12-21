ADMIN_PREFIX  = 'admin '
ADMIN_MARKER  = 'for another partner'
UNDERSCORE  = '_'

DASH  = '-'
SPACE = ' '
BLANK = ''
DOUBLE_SPACE  = '  '

def build_request scenario:, resource:, action:
  request = "#{resource.to_s}/"
  request << ADMIN_PREFIX if scenario.include? ADMIN_MARKER
  request << "#{action.to_s} #{scenario.sub(ADMIN_MARKER, BLANK).downcase} request"

  request.gsub(DOUBLE_SPACE, UNDERSCORE).gsub(DASH, UNDERSCORE).gsub(SPACE, UNDERSCORE)
end
