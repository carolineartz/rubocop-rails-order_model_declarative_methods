require 'pry'

module RuboCop
  module Cop
    module Rails
      class ModelCallback < Cop
        MSG = "not sorted"

        Associations = %i[
          belongs_to
          has_many
          has_one
          has_and_belongs_to_many
        ].freeze

        Callbacks = %i[
          after_initialize
          after_find
          after_touch

          before_validation
          validates
          validate
          after_validation

          before_save
          around_save
          before_create
          around_create
          before_update
          around_update
          before_destroy
          around_destroy

          after_destroy
          after_update
          after_create
          after_save
          after_commit
          after_rollback
        ].freeze

        Others = %i[
          attr_readonly
          serialize
        ]

        def on_class(node)
          _name, _superclass, body = *node
          return unless body
          return unless body.begin_type?

          callbacks = body.children.compact.select{|x| x.send_type? && methods.include?(x.method_name)}
          return if callbacks == sort_callbacks(callbacks)

          add_offense(callbacks.first, :expression)
        end


        private

        def methods
          [Associations, Callbacks, Others].flatten
        end

        def sort_callbacks(callbacks)
          callbacks.sort_by{|x| methods.find_index(x.method_name)}
        end
      end
    end
  end
end
