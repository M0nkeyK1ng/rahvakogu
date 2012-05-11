module ActiveRecord
  module Acts
    module SetSubInstance
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Not with idea accos
        def default_scope
          if not ["comments","tags","users","groups","ideas","points","ads","rakings"].include?(table_name)
            # Do nothing
          elsif table_name=="users"
            # Do nothing for now
          elsif table_name=="groups"
            where(:sub_instance_id=>SubInstance.current ? SubInstance.current.id : nil)
          elsif table_name=="ideas"
            where(:sub_instance_id=>SubInstance.current ? SubInstance.current.id : nil).
            where("ideas.group_id = 1 OR ideas.group_id IN (#{(Thread.current[:current_user] and not Thread.current[:current_user].groups.empty?) ? Thread.current[:current_user].groups.map{|g| g.id}.to_s.gsub("[","").gsub("]","") : "-1"})")
          elsif ["comments","tags","users"].include?(table_name)
            where(:sub_instance_id=>SubInstance.current ? SubInstance.current.id : nil)
          else
            where(:sub_instance_id=>SubInstance.current ? SubInstance.current.id : nil).
            where("ideas.group_id = 1 OR ideas.group_id IN (#{(Thread.current[:current_user] and not Thread.current[:current_user].groups.empty?) ? Thread.current[:current_user].groups.map{|g| g.id}.to_s.gsub("[","").gsub("]","") : "-1"})").
            includes(:idea)
          end
        end

        def acts_as_set_sub_instance(options = {})
          belongs_to :sub_instance
          before_create :set_sub_instance

          class_eval <<-EOV
            include SetSubInstance::InstanceMethods
          EOV
        end
      end

      module InstanceMethods
        def set_sub_instance
    # DISABLED HACK
    #      if self.class.class_name=="Activity" and self.idea and self.idea.sub_instance
    #        self.sub_instance_id = self.idea.sub_instance.id
    #      else
            self.sub_instance_id = SubInstance.current.id
    #      end
        end
      end
    end
  end
end