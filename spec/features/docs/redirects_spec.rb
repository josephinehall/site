# frozen_string_literal: true

RSpec.feature "Docs / Redirects" do
  it "redirects versionless (root) doc URLs to the latest version" do
    visit "/docs/dry-types"

    redirected_path = URI(current_url).path
    expect(redirected_path).to eq "/docs/dry-types/v1.8"
  end

  it "redirects versionless (deep) doc URLs to the latest version" do
    visit "/docs/dry-types/constraints"

    redirected_path = URI(current_url).path
    expect(redirected_path).to eq "/docs/dry-types/v1.8/constraints"
  end
end
