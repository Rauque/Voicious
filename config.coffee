###

Copyright (c) 2011-2012  Voicious

This program is free software: you can redistribute it and/or modify it under the terms of the
GNU Affero General Public License as published by the Free Software Foundation, either version
3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this
program. If not, see <http://www.gnu.org/licenses/>.

###

##
# Voicious configuration file
# Don't forget to recompile it after any changes
##

Logger  = require './logger'

exports.SERVER_PORT = 4242
exports.LOG_PATH = __dirname + '/log/'
exports.TPL_PATH = __dirname + '/includes/tpl/'
exports.STATIC_FILES_PATH = 'includes'
exports.SERVICES_PATH = '/test/'

exports.LOGLEVEL    = Logger.DEBUG
exports.LOGONSTDOUT = true
exports.PATH_ROUTES = ['client', 'user']
