# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::FaceMatcher do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:other) { create(:user, organization: organization) }

  let(:embedding_a) { Array.new(128) { 0.1 } }
  let(:embedding_b) { Array.new(128) { 0.9 } }

  before do
    ActsAsTenant.with_tenant(organization) do
      user.face_embeddings.create!(vector: embedding_a)
      other.face_embeddings.create!(vector: embedding_b)
    end
  end

  def matcher(embedding, threshold: nil)
    described_class.new(
      embedding: embedding,
      embeddings: FaceEmbedding.where(organization: organization).includes(:user),
      threshold: threshold
    )
  end

  it "matches the nearest embedding within the threshold" do
    match = matcher(embedding_a).perform

    expect(match).to be_present
    expect(match.user).to eq(user)
    expect(match.distance).to be_within(0.0001).of(0.0)
  end

  it "returns nil when nothing is within the threshold" do
    expect(matcher(Array.new(128) { 0.5 }, threshold: 0.05).perform).to be_nil
  end

  it "returns nil for an empty embedding" do
    expect(matcher([]).perform).to be_nil
  end

  describe ".euclidean_distance" do
    it "is zero for identical vectors" do
      expect(described_class.euclidean_distance([ 1, 2, 3 ], [ 1, 2, 3 ])).to eq(0.0)
    end

    it "is nil for mismatched dimensions" do
      expect(described_class.euclidean_distance([ 1, 2 ], [ 1, 2, 3 ])).to be_nil
    end
  end
end
