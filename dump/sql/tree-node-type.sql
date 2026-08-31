SELECT
    id,
    case
        when p_id IS NULL
            then 'Root'
        when EXISTS (
            SELECT 1
            FROM tree prev
            WHERE prev.p_id = t.id
        )
            then 'Inner'
        else 'Leaf'
    end "type"
FROM tree t
