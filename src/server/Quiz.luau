-- Questions and correct answers stay on the server. Each run gets one question per subject.
local Quiz = {}
local bank = {
    {
        {Id='addition', Text='What is 7 + 8?', Answers={'15','14','16'}, Hint='Start at 8, then count seven more.', Explanation='7 + 8 = 15. Nice mental maths!'},
        {Id='multiply', Text='Three desks have four pencils each. How many pencils?', Answers={'12','7','16'}, Hint='Add four pencils three times.', Explanation='3 × 4 = 12 pencils.'},
        {Id='divide', Text='Share 18 books equally between 3 shelves. How many per shelf?', Answers={'6','9','3'}, Hint='Which number, added three times, makes 18?', Explanation='18 ÷ 3 = 6 books on each shelf.'},
    },
    {
        {Id='planet', Text='Which planet do we live on?', Answers={'Earth','Mars','Saturn'}, Hint='Our home is the third planet from the Sun.', Explanation='Earth: home of oceans, people, and too much homework.'},
        {Id='ice', Text='What does ice become when it melts?', Answers={'Liquid water','Stone','More homework'}, Hint='Think of an ice cube in a warm drink.', Explanation='Melting turns solid ice into liquid water.'},
        {Id='magnet', Text='Which object will a magnet attract?', Answers={'Iron nail','Wooden ruler','Plastic cup'}, Hint='Magnets attract iron, but not every material.', Explanation='Iron is magnetic. Wood and plastic are not.'},
    },
    {
        {Id='library', Text='School survival: where do the books sleep?', Answers={'On the bookshelf','In the swimming pool','Inside a sandwich'}, Hint='Pick the place where books belong.', Explanation='On the bookshelf. Please keep them out of your lunch.'},
        {Id='bell', Text='The final bell rings. What is your escape destination?', Answers={'The school bus','Extra detention','Question 1,001'}, Hint='Look for the big yellow vehicle outside.', Explanation='The school bus! Two rooms stand between you and freedom.'},
        {Id='pencil', Text='Which classroom object gets shorter the more you sharpen it?', Answers={'A pencil','A desk','The professor'}, Hint='It has a point and writes your answers.', Explanation='A pencil. The professor remains the same height.'},
    },
}

function Quiz.NewDeck(random)
    random = random or Random.new()
    local deck = {}
    for category, questions in bank do
        local source = questions[random:NextInteger(1,#questions)]
        local order = {1,2,3}
        for i=3,2,-1 do local j=random:NextInteger(1,i); order[i],order[j]=order[j],order[i] end
        local q={Id=source.Id, Category=category, Text=source.Text, Answers={}, Hint=source.Hint, Explanation=source.Explanation}
        for i,answer in order do
            q.Answers[i]=source.Answers[answer]
            if answer==1 then q.Correct=i end
        end
        table.insert(deck,q)
    end
    return deck
end

function Quiz.View(state)
    local q=state.QuizDeck[state.Quiz+1]
    if not q then return nil end
    return {Index=state.Quiz+1,Total=#state.QuizDeck,Text=q.Text,Answers=table.clone(q.Answers),Subject=({'MATHS','SCIENCE','SCHOOL SURVIVAL'})[q.Category]}
end
return Quiz
