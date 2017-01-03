module Gh
  def self.auth(access_token : String)
    id = Fiber.current.object_id
    prev = Client.access_tokens[id]?
    Client.access_tokens[id] = access_token
    begin
      yield
    ensure
      if prev
        Client.access_tokens[id] = prev
      end
    end
  end

  TRAILING_GIT = /\.git$/

  def self.owner_and_repo_from_url(url)
    a = url.split("/")
    repo = a[-1]?.to_s.sub(TRAILING_GIT, "")
    owner = a[-2]?.to_s.split(":").last?.to_s
    {owner, repo}
  end
end
