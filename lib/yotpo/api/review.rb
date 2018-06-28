module Yotpo
  module Review

    # Creates a new review in Yotpo
    #
    # @param [Hash] params
    # @option params [String] :app_key the app key of the account for which the review is created
    # @option params [String] :product_id the id of the product
    # @option params [String] :shop_domain the domain of the account
    # @option params [String] :product_title the name of the product for which the review is created
    # @option params [String] :product_description the description of the product for which the review is created
    # @option params [String] :product_url the url of the product for which the review is created
    # @option params [String] :product_image_url the image url of the product for which the review is created
    # @option params [String] :user_display_name the author name
    # @option params [String] :user_email the author email
    # @option params [String] :review_body the review itself
    # @option params [String] :review_title the review title
    # @option params [String Integer] :review_score the rating of the review
    # @option params [String] :user_id External user id, can be used later on to retrieve reviews associated with this user
    # @option params [Hash] :custom_fields hash of custom field values
    # @option params [String] :signature for verified reviewers
    # @option params [String] :timestamp timestamp required for trusted vendors
    # @option params [String] :reviewer_type 'verified_buyer' or 'verified_reviewer'

    # @return [::Hashie::Mash] The new review with all of it's data
    def create_review(params)
      request = {
          appkey: params[:app_key],
          sku: params[:product_id],
          domain: params[:shop_domain],
          product_title: params[:product_title],
          product_description: params[:product_description],
          product_url: params[:product_url],
          product_image_url: params[:product_image_url],
          display_name: params[:user_display_name],
          email: params[:user_email],
          review_content: params[:review_body],
          review_title: params[:review_title],
          review_score: params[:review_score],
          user_reference: params[:user_id],
          custom_fields: params[:custom_fields],
          product_tags: params[:product_tags],

          signature: params[:signature],
          time_stamp: params[:timestamp],
          reviewer_type: params[:reviewer_type]
      }
      request.delete_if { |element, value| value.nil? }
      post('/reviews/dynamic_create', request)
    end

    # Gets a specific review in Yotpo
    #
    # @param [Hash] params
    # @option params [String] :id the id of the review
    # @option params [String] :utoken oauth token
    # @return [::Hashie::Mash] The review with all of it's data
    def get_review(params)
      review_id = params[:id]
      utoken = params[:utoken]
      get("/reviews/#{review_id}", { utoken: utoken })
    end

    #
    # Gets reviews of all products
    #
    # @param [Hash] params
    # @option params [String] :app_key the app key of the account for which the review is created
    # @option params [String] :product_id the id of the product
    # @option params [Integer] :count the amount of reviews per page
    # @option params [Integer] :page the page number
    # @option params [String] :since_id the id from which to start retrieving reviews
    # @option params [String] :since_date the date from which to start retrieving reviews
    # @option params [String] :since_updated_at Earliest update date of returned reviews
    # @option params [String] :utoken the users utoken to get the reviews that are most relevant to that user
    # @option params [String] :user_reference Filter by user reference
    # @option params [Boolean] :include_site_reviews Include site reviews
    # @option params [Boolean] :deleted Include deleted reviews

    def get_all_reviews(params)
      app_key = params[:app_key]
      sku = params[:product_id]
      request = {
          utoken: params[:utoken],
          since_id: params[:since_id],
          since_date: params[:since_date],
          since_updated_at: params[:since_updated_at],
          count: params[:per_page] || 20,
          page: params[:page] || 1,
          include_site_reviews: params[:include_site_reviews],
          deleted: params[:deleted],
          user_reference: params[:user_reference]
      }
      request.delete_if{|key,val| val.nil? }
      get("/v1/apps/#{app_key}/reviews", request)
    end

    #
    # Gets reviews of a specific product
    #
    # @param [Hash] params
    # @option params [String] :app_key the app key of the account for which the review is created
    # @option params [String] :product_id the id of the product
    # @option params [Integer] :count the amount of reviews per page
    # @option params [Integer] :page the page number
    def get_product_reviews(params)
      app_key = params[:app_key]
      sku = params[:product_id]
      page = params[:page]
      page_size = params[:per_page]
      star = params[:star]
      sort = params[:sort]
      sort_direction = params[:sort_direction]

      request = {
        page: page,
        per_page: page_size,
        star: star,
        sort: sort,
        direction: sort_direction
      }
      request.delete_if{|key,val| val.nil? }
      get("/v1/widget/#{app_key}/products/#{sku}/reviews.json", request)
    end

    def add_vote_to_review(params)
      get("reviews/#{params[:review_id]}/vote/#{params[:vote_value]}")
    end


    #
    # Gets bottomline of a specific product
    #
    # @param [Hash] params
    # @option params [String] :app_key the app key of the account for which the review is created
    # @option params [String] :product_id
    def get_product_reviews_bottomline(params)
      app_key = params[:app_key]
      product_id = params[:product_id]
      get("products/#{app_key}/#{product_id}/bottomline")
    end

    #
    # Gets bottom line for site reviews
    #
    # @param [Hash] params
    # @option params [String] :app_key the app key of the account for which the review is created
    def get_site_reviews_bottomline(params)
      app_key = params[:app_key]
      get("products/#{app_key}/yotpo_site_reviews/bottomline")
    end

    #
    # Gets data for site reviews widget
    #
    # @param [Hash] params
    # @option params [String] :app_key the app key of the account for which the review is created
    def get_site_reviews_widget(params)
      app_key = params[:app_key]
      page = params[:page]
      page_size = params[:per_page]
      star = params[:star]
      sort = params[:sort]
      sort_direction = params[:sort_direction]

      request = {
        page: page,
        per_page: page_size,
        star: star,
        sort: sort,
        direction: sort_direction
      }
      request.delete_if{|key,val| val.nil? }
      get("v1/widget/#{app_key}/products/yotpo_site_reviews/reviews.json", request)
    end

    # Convert reviews to site and product reviews
    #
    # @param [Hash] params
    # @option params [String] :utoken oauth token
    # @option params [String] :review_ids array of review ids to convert
    def convert_reviews_to_site_and_product(params)
      utoken = params[:utoken]
      review_ids = params[:review_ids]

      request = {
        utoken: utoken,
        review_ids: review_ids,
        review_action: "change_mention_status",
        attributes: [
          {
            type: "product",
            published: "1"
          },
          {
            type: "site",
            published: "1"
          }
        ],
        sync: true
      }

      request.delete_if{|key,val| val.nil? }
      put("reviews/async_update", request)
    end
  end
end
