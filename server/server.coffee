approved = (name) ->
	return false unless name?
	name is 'J.K' or WList.findOne(username:name)?

share.approved = approved

Meteor.publish "post", (username, id)->
	if approved username
		Posts.find _id: id

Meteor.publish "fullpost", (username, id)->
	if approved username
		Posts.find $or: [{_id: id}, {parent:id}]

Meteor.publish "posts", (username)->
	if approved username #and username? in ['j.k'] #<--this works! so we will add white-list
		Posts.find {} #parent:null #,
			#fields:
			#	content:false
				#owner:false

Meteor.publish "comments", (username, id)->
	if approved username and id?
		Posts.find parent:id #,
			###
				fields:
				content:false
				#owner:false
			###
Meteor.publish "likes", (postid)->
	Likes.find post:postid

Meteor.publish "appusers", (userid) ->
	if userid?
		Meteor.users.find()

Meteor.methods
	# {content:'',owner:'',date:'',parent:''}
	'postOwner':(id) ->
		# this doesn't work
		posts = (Posts.find _id: id).fetch()
		userid = posts[0].owner
		usr = (Meteor.users.find _id: userid).fetch()[0]
		console.log usr.emails?[0].address
		usr.emails[0].address
		if usr? 
			if usr.profile? 
				usr.profile.name 
			else 
				usr.emails?[0].address
		else
			userid 
		
	'addUser':(username, newname)->
		if approved username
			WList.insert 
				username: newname 
				by: username

	'removeUser':(username, thename)->
		if username is 'J.K'
			WList.remove 
				username: thename 
		
	'addPost':(options)->
		username = Meteor.user().username
		unless approved username
			return
		date = new Date()
		pid = options.parent
		post = {
			title: options.title
			content: options.content
			owner: username #"#{Meteor.user().username}(#{Meteor.user().emails[0].address})" #if (em = Meteor.user().emails?[0]?.address)? then em else Meteor.userId()
			date: date
			parent: pid
		}
		
		if pid?
			Posts.update pid,
				$set: lastCommentDate: date
				#$add: comments: [post] #<-- should this update the comments property?
		else
			post.lastCommentDate = date  
		
		Posts.insert post
		#console.log post, (Posts.find date: post.date).fetch()

	'removePost':(id)->
		Posts.remove _id:id
	
	'removeAllPosts':()->
		Posts.remove {}
###
	'addNames':()->
		Meteor.users.update 'tgHnK8gQ46GXRAGtv', $set: {'profile.fullname': 'Mike Tyson' }
		Meteor.users.update 'Xr9viZQzp6KbvX6b7', $set: {'profile.fullname': 'Evander Holyfield' }
###