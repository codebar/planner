module OmniAuthSpecHelpers
  def authenticate_as(member)
    OmniAuth.config.add_mock(:github,
                             {uid: member.auth_services.first.uid,
                              credentials: {token: "token",
                                            secret: "secret"}
                             })
  end
end
