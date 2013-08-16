

_ = require('underscore')
API = require('../config').API

class Group

  constructor: (APIClient, options) ->
    @APIClient = APIClient
    @params =
      openid: options.openid
      openkey: options.openkey
      pf: options.pf
    @groupOpenId = options.groupopenid
    @result = {
      organization:
        openId: options.groupopenid
      user: {}
      members: {}
    }

  fetch: (callback) ->
    @fetchUser((err, self) =>
      return callback(err) if err
      @result.user = self
      @fetchGroup()

      members = []
      @fetchIdentity((err, identity) =>
        return callback(err) if err
        @fetchGroupMembers((err, allUsers) =>
          return callback(err) if err
          for user in allUsers
            if user.openId is self.openId
              user.isAdmin = identity.isAdmin
              user.isOwner = identity.isOwner or false

            members[user.openId] = user
          @fetchGroupMembercards(members, (err, finalMembers) =>
            @result.members = finalMembers
            callback(err, @result)
          )
        )
      )
    )

  fetchUser: (callback) ->
    api = API.get_info
    @APIClient.call(api, @params, (data)->
      if data.openid
        callback(null, _itemToUser(data))
      else callback(data)
    )

  fetchIdentity: (callback) ->
    api = API.get_member_identity
    currentParams = _.clone(@params)
    currentParams.group_openid = @groupOpenId

    @APIClient.call(api, currentParams, (data) ->
      return callback(data) unless data.identity
      result = {}
      switch data.identity
        when 2
          result.isAdmin = true
          result.isOwner = true
        when 3, 4
          result.isAdmin = true
        else result.isAdmin = false
      callback(null, result)
    )

  fetchGroupMembers: (callback) ->

    api = API.get_group_members
    memberParams = _.clone(@params)
    memberParams.group_openid = @groupOpenId

    @APIClient.call(api, memberParams, (data) =>
      return callback(data) unless data.openid_list
      list = []

      for key, val of data.openid_list
        list.push(val)

      total = list.length
      num = parseInt(total/100)
      float = total%100
      all = []
      console.log "成员总数: #{total}, #{num + 1} 次请求成员列表"
      if num is 0
        all = [ list.join('_') ]
      else
        for i in [1..num]
          j = i - 1
          all.push(list[j*100..i*100].join('_'))
      if float
        all.push(list[num*100..num*100+float].join('_'))

      totalUsers = []
      count = all.length

      for fids in all
        @fetchMultiUsersInfo fids, (err, users) ->
          return callback(err) if err
          totalUsers = totalUsers.concat(users)
          count--
          callback(null, totalUsers) unless count
    )


  fetchMultiUsersInfo: (fopenids, callback) ->
    # 批量抓取用户数据

    api = API.get_multi_info
    infoParams = _.clone(@params)
    infoParams.fopenids = fopenids

    @APIClient.call(api, infoParams, 'post', (data) =>
      return callback(data) unless data.items
      users = []

      for item in data.items
        users.push(_itemToUser(item))
      callback(null, users)
    )

  fetchGroupMembercards: (members, callback) ->
    api = API.get_group_membercards
    cardsParams = _.clone(@params)
    cardsParams.group_openid = @groupOpenId

    @APIClient.call(api, cardsParams, (data) =>
      return callback(data) unless data.openid_card
      finalMembers = []
      for card in data.openid_card
        members[card.openid].name = card.cards
        finalMembers.push(members[card.openid])
      return callback(null, finalMembers)
    )

  fetchGroup: (callback)->
    api = API.get_all_groups
    @APIClient.call(api, @params, (data) =>
      for group in data.group_list
        if group.group_openid is @groupOpenId
          @result.organization.name = unescape(group.group_name)
      callback and callback(null, @result)
    )

_itemToUser = (item) ->
  user =
    openId: item.openid
    location: item.city
    avatarUrl: item.figureurl
    email: "#{item.openid.toLowerCase()}@mail.teambition.com"
    name: unescape(item.nickname)
  return user

module.exports = Group