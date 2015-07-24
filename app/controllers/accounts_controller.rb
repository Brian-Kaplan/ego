# Author: Brian Kaplan

class AccountsController < ApplicationController

	def index
		@accounts = Account.order(link_karma: :desc)
		@count = 0
	end

	def show
		@account = Account.find(params[:id])
	end
	
	def new
		@account = Account.new
	end

	def edit
	  	@account = Account.find(params[:id])
	end

	def create
		@account = Account.new(account_params)
 		@account = getLinkKarma(@account)
  		if @account.save
  			redirect_to @account
  		else
  			render 'new'
  		end
	end

	def update
		@account = Account.find(params[:id])
		@account = getLinkKarma(@account)
		if @account.update(:link_karma => @account.link_karma)
			@accounts = Account.order(link_karma: :desc)
			@count = 0
			render 'index'
		else
			render 'edit'
		end
	end

	def destroy
		@account = Account.find(params[:id])
		@account.destroy

		redirect_to accounts_path
	end

	def updateALL
		@accounts = Account.order(link_karma: :desc)
		@count = 0
		for i in 1..@accounts.length
			@account = Account.find(i)
			@account = getLinkKarma(@account)
			@account.update(:link_karma => @account.link_karma)
		end
		render 'index'
	end

	def scrapeFrontPage
		@count = 0
		getJson
		i = 0
		while i < @authorArray.length
			@account = Account.new
			@account.rname = @authorArray.at(i)
			@account = getLinkKarma(@account)
			if not Account.exists?(rname: @account.rname)
				@account.save
			end
			i+=1
		end
		@accounts = Account.order(link_karma: :desc)
		render 'index'
	end

	private
		def account_params
			params.require(:account).permit(:rname, :link_karma)
		end

	private 
	def getLinkKarma(account)
		user = RedditKit.user account.rname
		if user != nil
			account.link_karma = user.link_karma
		end
		return account
	end

	private
	def getJson
		@response = HTTParty.get("https://www.reddit.com/r/all/.json")
		@result = @response.body
		http_party_json = JSON.parse(@response.body)
		count = 0
		@authorArray = Array.new
		while count < 25 
			author = http_party_json['data']['children'][count]['data']['author']
			@authorArray << author
			count+=1
		end
	end
end
