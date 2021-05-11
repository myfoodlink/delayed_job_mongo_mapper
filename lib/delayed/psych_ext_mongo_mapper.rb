module Psych
  module Visitors
    class ToRuby
      prepend ::PsychVisitorsDelayedJobMongoMapperExtensions
    end
  end
end


module PsychVisitorsDelayedJobMongoMapperExtensions
  def klass(object)
    return revive(Psych.load_tags[object.tag], object) if Psych.load_tags[object.tag]

    case object.tag
    when /^!ruby\/MongoMapper:(.+)$/
      klass = resolve_class($1)
      payload = Hash[*object.children.map { |c| accept c }]
      begin
        klass.find!(payload["attributes"]["_id"])
      rescue MongoMapper::DocumentNotFound
        raise Delayed::DeserializationError
      end
    else
      super(object)
    end
  end
end