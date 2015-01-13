require 'spec_helper'

describe Link do 

  context 'Demonstration of how datamapper works' do

    # This is not a real test, it's simply a demo of how it works
    it 'should be created and then retrieved from the db' do
      # in the beginning our database is empty, so there are no links
      expect(Link.count).to eq(0)
      # this creates it in the database, so it's stored on the disk
      Link.create(title: 'Makers Academy',
                  url:   'http://www.makersacademy.com/')
      expect(Link.count).to eq(1)
      link = Link.first
      expect(link.url).to eq('http://www.makersacademy.com/')
      expect(link.title).to eq('Makers Academy')
      # if we want to, we can destroy it
      link.destroy
      # so now we have no links in the database
      expect(Link.count).to eq(0)
    end

  end
end