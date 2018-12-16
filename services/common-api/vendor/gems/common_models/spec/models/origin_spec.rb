# coding: utf-8
# frozen_string_literal: true

require 'spec_helper.rb'

RSpec.describe CommonModels::Origin, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:contributions) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:domain) }
  end

  describe 'uniqueness' do
    let(:platform) { create(:platform) }
    subject { CommonModels::Origin.new(platform: platform, domain: '') }
    it { is_expected.to validate_uniqueness_of(:domain).scoped_to(:referral) }
  end

  describe '#process_hash' do
    let(:domain) { nil }
    let(:referral) { nil }
    let(:platform) { create(:platform) }

    subject { CommonModels::Origin.process_hash({ ref: referral, domain: domain }, platform) }

    context 'with ref' do
      context 'when referral already exists into database with the same origin domain' do
        let(:domain) { 'www.trendnotion.com' }
        let(:referral) { 'explore' }
        let!(:origin) { create(:origin, platform: platform, domain: 'trendnotion.com', referral: referral) }
        it 'should return the already created origin' do
          is_expected.to eq origin
        end
      end

      context 'when referral should not exists' do
        let(:domain) { 'http://m.facebook.com/posts/123123/lorem' }
        let(:referral) { 'fb_test' }
        let!(:origin) { create(:origin, platform: platform, domain: 'lorem.com', referral: referral) }

        it 'should store and return a new origin' do
          expect(subject.domain).to eq 'm.facebook.com'
          expect(subject).to_not eq(origin)
        end
      end
    end

    context 'without ref' do
      let(:domain) { 'google.com' }
      let(:referral) { nil }
      it 'should store without ref' do
        is_expected.to_not eq(nil)
        expect(subject.domain).to eq(domain)
      end
    end

    context 'without origin domain' do
      let(:domain) { nil }
      it 'should return nil without domain' do
        is_expected.to eq(nil)
      end
    end
  end
end
