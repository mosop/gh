module Gh
  TRAILING_GIT = /\.git$/

  def self.owner_and_repo_from_url(url)
    a = url.split("/")
    repo = a[-1]?.to_s.sub(TRAILING_GIT, "")
    owner = a[-2]?.to_s.split(":").last?.to_s
    {owner, repo}
  end
end
