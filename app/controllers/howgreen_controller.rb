require 'json'
require 'net/http'
class HowgreenController < ApplicationController
  def index
  end

  def new
  end

	def create
		jobs_url = "https://#{params[:pipeline][:concourse_url]}/api/v1/pipelines/#{params[:pipeline][:pipeline_name]}/jobs"
    puts jobs_url
		uri = URI.parse(jobs_url)
    response = Net::HTTP.get_response(uri)
		builds = JSON.parse(response.body)
		succeeded = 0
		failed = 0
		num_builds = 0

		builds.each do | build |
			if build["finished_build"]["status"] == "succeeded"
				 succeeded +=1
			end

			if build["finished_build"]["status"] == "failed"
				 failed +=1
			end

    end

		pipeline_status = pipeline_status(failed, succeeded)
		if pipeline_status == "green"
			giphy_url = "http://media0.giphy.com/media/Hq2XDestpCXq8/giphy.webp"
		else
		  giphy_url = "http://api.giphy.com/v1/gifs/search?q=#{pipeline_status}\&api_key=dc6zaTOxFJmzC\&rating=pg"
			giphy_response = Net::HTTP.get_response(URI.parse(giphy_url))
			giphy_json = JSON.parse(giphy_response.body)
			giphy_url = giphy_json["data"].sample["images"]["original"]["webp"]
		end

		render inline: "<html><img src=\"#{giphy_url}\"/></html>"
  end

	private

	def pipeline_status(failed, succeeded)
	  percent = (succeeded / (failed + succeeded))*100
		case percent
		when 95..100
			return "green"
		when 90..94
		  return ["success","yay","happy"].sample.html_safe 
		when 50..89
			return ["meh","fire","sad"].sample.html_safe
		else
			return "fail".html_safe
		end
	end
end
