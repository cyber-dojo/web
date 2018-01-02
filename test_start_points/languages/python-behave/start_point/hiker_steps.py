from behave import *
from hiker import Hiker

@given(u'the hitch-hiker selects some tiles')
def step_impl(context):
    pass

@when(u'they spell {tile1:d} times {tile2:d}')
def step_impl(context, tile1, tile2):
    douglas = Hiker()
    context.tileproduct = douglas.answer(tile1, tile2);

@then(u'the score is {answer:d}')
def step_impl(context, answer):
    assert context.tileproduct is answer
