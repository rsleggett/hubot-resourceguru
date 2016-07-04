# Description
#   Tells you what you're working on today
#
# Configuration:
#   Add HUBOT_RESOURCE_GURU_AUTH environment variable with basic auth string
#
# Commands:
#   hubot today
#
# Notes: 
#   Needs work
#
# Author:
#   Rob SL @ Building Blocks

AUTH = process.env.HUBOT_RESOURCE_GURU_AUTH
BASE_URL = "https://api.resourceguruapp.com/v1/buildingblocks"
    
getToday = ->
    date = new Date
    yyyy = date.getFullYear()
    mm = date.getMonth()
    dd = date.getDay()
    return "#{yyyy}-#{mm}-#{dd}"

getTomorrow = ->
    date = new Date
    yyyy = date.getFullYear()
    mm = date.getMonth()
    dd = date.getDay()+1
    return "#{yyyy}-#{mm}-#{dd}"

module.exports = (robot) ->
    robot.respond '/today/i', (response) -> 
        userid = robot.brain.get "resource-guru-#{response.message.user.id}"
        if !userid
            response.send 'Tell me your Resource Guru user id first with resource-guru-me <id>'
            return
        startDate = getToday()
        endDate = getToday()
        robot.http("#{BASE_URL}/resources/#{userid}/bookings?start_date=#{startDate}&end_date=#{endDate}")
            .header("Authorization", AUTH)
            .get() (err, res, body) ->
                if err 
                    response.send "Could not get Resource Guru #{err}"
                    return
                
                bookings = JSON.parse(body)
                robot.http("#{BASE_URL}/projects/#{bookings[0].project_id}")
                    .header("Authorization", AUTH)
                    .get() (err1, res1, body1) ->
                        if err
                            response.send "Could not get Resource Guru Project #{err1}"
                            return
                        # response.send "Got #{body1}"
                        project = JSON.parse(body1)
                        response.send "You should be booked on #{project.name} for #{project.client.name} today"
    robot.respond /resource-guru-me (.*)/, (response) ->
         id = response.match[1].trim()
         robot.brain.set "resource-guru-#{response.message.user.id}", id
         response.send "Set your id to #{id}"
    #robot.respond 'tomorrow', (response) ->
    #    response.send "Mention was #{userName}"
