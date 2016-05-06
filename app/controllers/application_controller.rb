class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

	def create
		if params["concourse_url"] == nil || params["pipeline_name"] == nil
			render plain: "usage http://howgreen.cfapps.io/?concourse_url=your.concourse.url.com&pipeline_name=your-pipeline-name"
			return
		end
		jobs_url = "https://#{params["concourse_url"]}/api/v1/pipelines/#{params["pipeline_name"]}/jobs"
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
			giphy_url = "http://media0.giphy.com/media/Hq2XDestpCXq8/giphy.gif"
		else
		  giphy_url = "http://api.giphy.com/v1/gifs/search?q=#{pipeline_status}\&api_key=dc6zaTOxFJmzC\&rating=g"
			giphy_response = Net::HTTP.get_response(URI.parse(giphy_url))
			giphy_json = JSON.parse(giphy_response.body)
			giphy_url = giphy_json["data"].sample["images"]["original"]["url"]
		end

		render inline: "<style>html { 
  background: url(#{giphy_url}) no-repeat center center fixed; 
  -webkit-background-size: cover;
  -moz-background-size: cover;
  -o-background-size: cover;
  background-size: cover;
}
</style>
<script>
setTimeout(function() {location.reload()}, 8000);
</script>
"
  end

	private

	def pipeline_status(failed, succeeded)
	  percent = (succeeded / (failed + succeeded))*100
		case percent
		when 95..100
			return "green"
		when 90..94
		  return ["success"].sample.html_safe 
		when 50..89
			return ["meh"].sample.html_safe
		else
			return "oops".html_safe
		end
	end
end
