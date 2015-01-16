window.client = new Faye.Client('/faye')

jQuery ->
  if user_id != undefined
    client.subscribe "/notify/#{user_id}", (payload) ->
      console.log payload
      eval(payload)
