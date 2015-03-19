require 'test_helper'

describe Json do
  describe :lock_values do
    specify { lock_values(hash).must_equal locked_hash }
    specify { lock_values(hash_array).must_equal locked_hash_array }
    specify { lock_values(nested_hash).must_equal locked_nested_hash }
    specify { lock_values(nested_array).must_equal locked_nested_array }
    specify { lock_values(params).must_equal locked_params }
    specify { lock_values(array).must_equal locked_array }

    def lock_values params
      Json.lock_values params
    end

    def hash
      {
        id: 20,
        string: 'string',
        number: 'number',
        boolean: true,
        nil: nil,
        order_number: 20,
        activity_at: '2015-03-03T00:30:00Z',
        created_at: '2015-02-28T16:00:00Z',
        updated_at: '2015-02-28T16:00:00Z'
      }
    end

    def locked_hash
      {
        id: 1,
        string: 'string',
        number: 'number',
        boolean: true,
        nil: nil,
        order_number: 1,
        activity_at: '2015-01-01T00:00:00Z',
        created_at: '2015-01-01T00:00:00Z',
        updated_at: '2015-01-01T00:00:00Z'
      }
    end

    def hash_array
      [
        {
          id: 500,
          name: 'name'
        },
        {
          id: 501,
          name: 'name'
        }
      ]
    end

    def locked_hash_array
      [
        {
          id: 1,
          name: 'name'
        },
        {
          id: 2,
          name: 'name'
        }
      ]
    end

    def nested_hash
      {
        id: 500,
        name: 'name',
        nested: {
          id: 500,
          name: 'name'
        }
      }
    end

    def locked_nested_hash
      {
        id: 1,
        name: 'name',
        nested: {
          id: 1,
          name: 'name'
        }
      }
    end

    def nested_array
      {
        id: 500,
        name: 'name',
        array: [
          {
            id: 500,
            name: 'name'
          },
          {
            id: 501,
            name: 'name'
          }
        ]
      }
    end

    def locked_nested_array
      {
        id: 1,
        name: 'name',
        array: [
          {
            id: 1,
            name: 'name'
          },
          {
            id: 2,
            name: 'name'
          }
        ]
      }
    end

    def array
      ['a', 'b', 'c']
    end

    def locked_array
      ['a', 'b', 'c']
    end

    def params
      [
        {
          id: 500,
          number: 30,
          order_number: 500,
          created_at: '2015-02-28T15:30Z',
          updated_at: '2015-02-28T15:30Z',
          name: 'name',
          nested: {
            id: 500,
            name: 'name',
            deep_nested: {
              id: 500,
              name: 'name'
            }
          },
          array: [
            {
              id: 500,
              name: 'name',
              nested: {
                id: 500,
                name: 'name',
                deep_array: [
                  {
                    id: 500,
                    name: 'name'
                  },
                  {
                    id: 500,
                    name: 'name'
                  }
                ]
              }
            },
            {
              id: 500,
              name: 'name'
            }
          ]
        }
      ]
    end

    def locked_params
      [
        {
          id: 1,
          number: 30,
          order_number: 1,
          created_at: '2015-01-01T00:00:00Z',
          updated_at: '2015-01-01T00:00:00Z',
          name: 'name',
          nested: {
            id: 1,
            name: 'name',
            deep_nested: {
              id: 1,
              name: 'name'
            }
          },
          array: [
            {
              id: 1,
              name: 'name',
              nested: {
                id: 1,
                name: 'name',
                deep_array: [
                  {
                    id: 1,
                    name: 'name'
                  },
                  {
                    id: 2,
                    name: 'name'
                  }
                ]
              }
            },
            {
              id: 2,
              name: 'name'
            }
          ]
        }
      ]
    end
  end
end
