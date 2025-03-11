# frozen_string_literal: true

require "yaml"

module Site
  module Content
    module Loaders
      # Loads gems and docs from content/docs/ into the database.
      class GemsDocs
        GemData = Data.define(:org, :slug, :latest_version, :hidden)
        DocData = Data.define(:org, :slug, :version, :hidden)

        YAML_PATH = "docs.yml"
        DOCS_KEY = :docs
        SLUG_KEY = :slug
        HIDDEN_KEY = :hidden

        include Deps[
          docs_relation: "relations.docs",
          gems_relation: "relations.gems"
        ]

        def call(root: DOCS_PATH)
          org_paths = root.glob("*")

          org_paths.each do |org_path|
            org = org_path.relative_path_from(root).to_s
            load_org(org:, org_path:)
          end
        end

        private

        def load_org(org:, org_path:)
          yaml_path = org_path.join(YAML_PATH)
          return unless yaml_path.file?

          yaml_docs = File.read(yaml_path)
            .then { YAML.load(it, symbolize_names: true) }
            .fetch(DOCS_KEY)

          docs = []
          yaml_docs.each do |yaml_doc|
            slug = yaml_doc.fetch(SLUG_KEY)

            hidden_versions = hidden_versions(yaml_doc[HIDDEN_KEY])
            versions_path = org_path.join(slug)
            versions = versions_path.glob("*").map { it.relative_path_from(versions_path).to_s }

            latest_version = (versions - hidden_versions).sort.last
            gem = GemData.new(
              org:,
              slug:,
              latest_version:,
              hidden: gem_hidden?(yaml_doc[HIDDEN_KEY])
            )
            gems_relation.insert(gem.to_h)

            versions.each do |version|
              docs << DocData.new(
                org:, slug:, version:,
                hidden: hidden_versions.include?(version)
              )
            end
          end
          docs_relation.multi_insert(docs.map(&:to_h))
        end

        def gem_hidden?(value)
          return false if value.is_a?(Array)
          !!value
        end

        def hidden_versions(value)
          return value if value.is_a?(Array)
          []
        end
      end
    end
  end
end
