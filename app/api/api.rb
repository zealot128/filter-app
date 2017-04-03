class API < Grape::API
  mount Resources::NewsItems
end
