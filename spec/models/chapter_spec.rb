require 'spec_helper'

describe Chapter do
  context 'validations' do
    context '#slug' do
      it 'a chapter must have a slug set' do
        chapter = Chapter.new(name: 'London', city: 'London', email: 'london@codebar.io')
        chapter.save

        expect(chapter.slug).to eq('london')
      end

      it 'the slug is parameterized' do
        chapter = Chapter.new(name: 'New York', city: 'New York', email: 'newyork@codebar.io')
        chapter.save

        expect(chapter.slug).to eq('new-york')
      end

      context 'scopes' do
        context '#default_scope' do
          it 'only returns active Chapters' do
            2.times { Fabricate(:chapter) }
            3.times { Fabricate(:chapter, active: false) }

            expect(Chapter.all.count).to eq(2)
          end
        end
      end
    end
  end
end
