pub struct Game(Vec<Option<usize>>);

const DIMENSION: usize = 81;

type Result<T> = std::result::Result<T, GameError>;

#[derive(Debug, Clone)]
pub struct GameError;

impl Game {
    pub fn new(input: Vec<Option<usize>>) -> Result<Self> {
        if input.len() == DIMENSION {
            Ok(Game(input))
        } else {
            Err(GameError)
        }
    }
}

impl std::fmt::Display for GameError {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "invalid game")
    }
}

impl std::error::Error for GameError {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        None
    }
}

fn main() {
    println!("Hello, world!");
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_new_game_valid() {
        let game = test_game();
        assert!(Game::new(game).is_ok());
    }

    #[test]
    fn test_new_game_empty() {
        let game = vec![];
        assert!(Game::new(game).is_err());
    }

    #[test]
    fn test_new_game_too_few() {
        let mut game = test_game();
        game.pop();
        assert!(Game::new(game).is_err());
    }

    #[test]
    fn test_new_game_too_many() {
        let mut game = test_game();
        game.push(Some(3));
        assert!(Game::new(game).is_err());
    }

    fn test_game() -> Vec<Option<usize>> {
        vec![
            Some(8),
            None,
            None,
            None,
            None,
            None,
            None,
            None,
            None,
            None,
            None,
            Some(3),
            Some(6),
            None,
            None,
            None,
            None,
            None,
            None,
            Some(7),
            None,
            None,
            Some(9),
            None,
            Some(2),
            None,
            None,
            None,
            Some(5),
            None,
            None,
            None,
            Some(7),
            None,
            None,
            None,
            None,
            None,
            None,
            None,
            Some(4),
            Some(5),
            Some(7),
            None,
            None,
            None,
            None,
            None,
            Some(1),
            None,
            None,
            None,
            Some(3),
            None,
            None,
            None,
            Some(1),
            None,
            None,
            None,
            None,
            Some(6),
            Some(8),
            None,
            None,
            Some(8),
            Some(5),
            None,
            None,
            None,
            Some(1),
            None,
            None,
            Some(9),
            None,
            None,
            None,
            None,
            Some(4),
            None,
            None,
        ]
    }
}
